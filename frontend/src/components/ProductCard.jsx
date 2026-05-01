import { ShoppingCart } from 'lucide-react';
import { formatCurrency } from '../api/api';

export default function ProductCard({ product, onAddToCart, disabled }) {
  const categoryName = product.category?.name || 'Uncategorized';
  const stock = Number(product.stock_quantity || 0);

  return (
    <article className="product-card">
      <div className="product-media">
        {product.image_url ? (
          <img src={product.image_url} alt={product.name} loading="lazy" />
        ) : (
          <div className="image-fallback">{product.name?.slice(0, 2).toUpperCase()}</div>
        )}
      </div>
      <div className="product-body">
        <div className="product-meta">
          <span>{categoryName}</span>
          <span className={stock > 0 ? 'stock-ok' : 'stock-empty'}>{stock} in stock</span>
        </div>
        <h3>{product.name}</h3>
        <p>{product.description || 'No description available.'}</p>
      </div>
      <div className="product-footer">
        <strong>{formatCurrency(product.price)}</strong>
        <button
          className="primary-button"
          type="button"
          onClick={() => onAddToCart(product)}
          disabled={disabled || stock <= 0}
        >
          <ShoppingCart size={17} aria-hidden="true" />
          Add
        </button>
      </div>
    </article>
  );
}
