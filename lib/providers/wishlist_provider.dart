import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';
import 'auth_provider.dart';

final wishlistServiceProvider = Provider<WishlistService>((ref) => WishlistService());

class WishlistState {
  final List<WishlistItemModel> items;
  final bool isLoading;

  WishlistState({
    this.items = const [],
    this.isLoading = false,
  });

  WishlistState copyWith({
    List<WishlistItemModel>? items,
    bool? isLoading,
  }) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistService _wishlistService;
  final Ref _ref;

  WishlistNotifier(this._wishlistService, this._ref) : super(WishlistState()) {
    loadWishlist();
  }

  String get _userId {
    final authState = _ref.read(authProvider);
    return authState.user?.id ?? 'guest-user';
  }

  Future<void> loadWishlist() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _wishlistService.getWishlist(_userId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  bool isProductWishlisted(String productId) {
    return state.items.any((item) => item.productId == productId);
  }

  Future<void> toggleWishlist(ProductModel product) async {
    final productId = product.id;
    if (isProductWishlisted(productId)) {
      await _wishlistService.removeFromWishlist(_userId, productId);
    } else {
      await _wishlistService.addToWishlist(_userId, product);
    }
    await loadWishlist();
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier(ref.watch(wishlistServiceProvider), ref);
});
