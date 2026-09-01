-- ==========================================
-- PERFUME SHOPPING APP - SUPABASE DATABASE SCHEMA
-- ==========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS TABLE (Linked to Supabase Auth)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    brand TEXT NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    discount_price NUMERIC(10, 2),
    size_ml INT NOT NULL DEFAULT 100,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    fragrance_family TEXT NOT NULL, -- Fresh, Floral, Gourmand, Spicy, Woody, Rose
    longevity TEXT NOT NULL DEFAULT 'Long Lasting (8-12 hrs)', -- Moderate, Long Lasting, Eternal
    top_notes TEXT[] DEFAULT '{}',
    middle_notes TEXT[] DEFAULT '{}',
    base_notes TEXT[] DEFAULT '{}',
    image_urls TEXT[] NOT NULL DEFAULT '{}',
    stock INT NOT NULL DEFAULT 50,
    rating NUMERIC(3, 2) DEFAULT 4.8,
    reviews_count INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    is_best_seller BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. WISHLIST TABLE
CREATE TABLE IF NOT EXISTS public.wishlist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, product_id)
);

-- 5. CART ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, product_id)
);

-- 6. ORDERS TABLE
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    total NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- pending, processing, shipped, delivered, cancelled
    shipping_address TEXT NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'Credit Card',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. ORDER ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE SET NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. REVIEWS TABLE
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    rating NUMERIC(2, 1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- 1. Users policies
CREATE POLICY "Users can view own user profile" 
    ON public.users FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own user profile" 
    ON public.users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
    ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. Categories & Products policies (Public read)
CREATE POLICY "Public categories are viewable by everyone" 
    ON public.categories FOR SELECT USING (true);

CREATE POLICY "Public products are viewable by everyone" 
    ON public.products FOR SELECT USING (true);

-- 3. Wishlist policies (Strict User isolation)
CREATE POLICY "Users can view own wishlist" 
    ON public.wishlist FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert into own wishlist" 
    ON public.wishlist FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete from own wishlist" 
    ON public.wishlist FOR DELETE USING (auth.uid() = user_id);

-- 4. Cart Items policies (Strict User isolation)
CREATE POLICY "Users can view own cart items" 
    ON public.cart_items FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert into own cart" 
    ON public.cart_items FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cart items" 
    ON public.cart_items FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete from own cart" 
    ON public.cart_items FOR DELETE USING (auth.uid() = user_id);

-- 5. Orders & Order Items policies
CREATE POLICY "Users can view own orders" 
    ON public.orders FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own orders" 
    ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own order items" 
    ON public.order_items FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE public.orders.id = public.order_items.order_id 
            AND public.orders.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert order items for own orders" 
    ON public.order_items FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE public.orders.id = public.order_items.order_id 
            AND public.orders.user_id = auth.uid()
        )
    );

-- 6. Reviews policies
CREATE POLICY "Reviews are viewable by everyone" 
    ON public.reviews FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create reviews" 
    ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- TRIGGER FOR AUTOMATIC USER PROFILE CREATION
-- ==========================================
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, name, email, avatar_url)
  VALUES (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)), 
    new.email,
    COALESCE(new.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================
-- SAMPLE SEED DATA
-- ==========================================
INSERT INTO public.categories (id, name, description, image_url) VALUES
('c1111111-1111-1111-1111-111111111111', 'Fresh', 'Crisp citrus, sea breeze, and green leaf notes', 'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=600&q=80'),
('c2222222-2222-2222-2222-222222222222', 'Floral', 'Enchanting jasmine, velvet rose, and orange blossom', 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=600&q=80'),
('c3333333-3333-3333-3333-333333333333', 'Gourmand', 'Rich Madagascar vanilla, roasted coffee, and tonka bean', 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=600&q=80'),
('c4444444-4444-4444-4444-444444444444', 'Spicy', 'Warm saffron, cardamom, pink pepper, and cinnamon', 'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?auto=format&fit=crop&w=600&q=80'),
('c5555555-5555-5555-5555-555555555555', 'Woody', 'Royal Oud, Mysore sandalwood, cedarwood, and vetiver', 'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=600&q=80'),
('c6666666-6666-6666-6666-666666666666', 'Rose', 'Opulent Damask rose, Turkish rose absolute, and amber', 'https://images.unsplash.com/photo-1595425970377-c9703cf48b6d?auto=format&fit=crop&w=600&q=80')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, brand, description, price, discount_price, size_ml, category_id, fragrance_family, longevity, top_notes, middle_notes, base_notes, image_urls, stock, rating, reviews_count, is_featured, is_best_seller) VALUES
(
    'p1111111-1111-1111-1111-111111111111',
    'Eternal Grace Extrait',
    'Maison Athena',
    'An unconventional, eccentric, and sensual floral composition. Eternal Grace opens with vibrant Bergamot and Magnolia before melting into a velvet heart of Damask Rose and Sambac Jasmine.',
    280.00,
    240.00,
    100,
    'c2222222-2222-2222-2222-222222222222',
    'Floral',
    'Long Lasting (10-14 hrs)',
    ARRAY['Italian Bergamot', 'Pink Pepper', 'White Magnolia'],
    ARRAY['Damask Rose', 'Sambac Jasmine', 'Iris Absolute'],
    ARRAY['Madagascar Vanilla', 'White Musk', 'Creamy Sandalwood'],
    ARRAY['https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=800&q=80', 'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=800&q=80'],
    35,
    4.9,
    128,
    true,
    true
),
(
    'p2222222-2222-2222-2222-222222222222',
    'Oud Noir Royal',
    'Yusuf Bhai Parfums',
    'A dark, regal elixir featuring rare Cambodian Oud blended with warm amber, roasted coffee, and smoky leather. Crafted for modern connoisseurs who command presence.',
    320.00,
    290.00,
    100,
    'c5555555-5555-5555-5555-555555555555',
    'Woody',
    'Eternal (14+ hrs)',
    ARRAY['Cardamom', 'Nutmeg', 'Smoky Frankincense'],
    ARRAY['Cambodian Oud', 'Cedarwood', 'Patchouli'],
    ARRAY['Ambergris', 'Leather', 'Dark Chocolate'],
    ARRAY['https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=800&q=80'],
    20,
    5.0,
    94,
    true,
    true
),
(
    'p3333333-3333-3333-3333-333333333333',
    'Velvet Vanilla Bourbon',
    'Atelier Gourmand',
    'Indulgent and comforting. Pure Tahitian vanilla pod infusion combined with salted caramel, warm tonka bean, and subtle notes of oak-aged bourbon.',
    195.00,
    165.00,
    75,
    'c3333333-3333-3333-3333-333333333333',
    'Gourmand',
    'Long Lasting (8-10 hrs)',
    ARRAY['Sweet Almond', 'Caramelized Sugar', 'Coconut Blossom'],
    ARRAY['Tahitian Vanilla', 'Bourbon Accord', 'Orchid'],
    ARRAY['Tonka Bean', 'White Amber', 'Cashmere Wood'],
    ARRAY['https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=800&q=80'],
    45,
    4.8,
    86,
    false,
    true
),
(
    'p4444444-4444-4444-4444-444444444444',
    'Soleil de Capri',
    'Riviera Fragrances',
    'A sun-drenched coastal escape. Effervescent Amalfi lemon, crushed mint leaves, and crisp ocean air grounded by soft solar woods.',
    170.00,
    150.00,
    100,
    'c1111111-1111-1111-1111-111111111111',
    'Fresh',
    'Moderate (6-8 hrs)',
    ARRAY['Amalfi Lemon', 'Crushed Mint', 'Mandarin'],
    ARRAY['Sea Salt Accord', 'Neroli', 'Green Tea'],
    ARRAY['Driftwood', 'Light Cedar', 'Musk'],
    ARRAY['https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?auto=format&fit=crop&w=800&q=80'],
    50,
    4.7,
    62,
    true,
    false
),
(
    'p5555555-5555-5555-5555-555555555555',
    'Saffron & Suede Nectar',
    'Maison Athena',
    'An alluring spicy masterpiece. Golden Iranian saffron weaves through crimson rose petals and soft Tuscan suede for a mesmerizing sillage.',
    260.00,
    225.00,
    100,
    'c4444444-4444-4444-4444-444444444444',
    'Spicy',
    'Long Lasting (10-12 hrs)',
    ARRAY['Iranian Saffron', 'Pink Pepper', 'Grapefruit'],
    ARRAY['Red Rose Absolute', 'Cinnamon Bark', 'Plum'],
    ARRAY['Tuscan Suede', 'Amberwood', 'Vanilla Resin'],
    ARRAY['https://images.unsplash.com/photo-1595425970377-c9703cf48b6d?auto=format&fit=crop&w=800&q=80'],
    15,
    4.9,
    74,
    true,
    true
)
ON CONFLICT (id) DO NOTHING;
