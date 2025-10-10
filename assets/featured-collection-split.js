/**
 * Featured Collection Split Component
 * Maneja la interactividad de la sección de colección dividida
 */

class FeaturedCollectionSplit {
  constructor() {
    this.init();
  }

  init() {
    this.setupVariantSelectors();
    this.setupAddToCartButtons();
    this.setupWishlistButtons();
  }

  setupVariantSelectors() {
    const variants = document.querySelectorAll('.variant');
    
    variants.forEach(variant => {
      variant.addEventListener('click', (e) => {
        const parentOptions = e.target.closest('.variant-options');
        const allVariants = parentOptions.querySelectorAll('.variant');
        
        // Remover clase selected de todos
        allVariants.forEach(v => v.classList.remove('selected'));
        
        // Agregar clase selected al clickeado
        e.target.classList.add('selected');
      });
    });
  }

  setupAddToCartButtons() {
    const addToCartButtons = document.querySelectorAll('.add-to-cart');
    
    addToCartButtons.forEach(button => {
      button.addEventListener('click', (e) => {
        e.preventDefault();
        
        const productCard = e.target.closest('.product-card');
        const selectedVariant = productCard.querySelector('.variant.selected');
        
        if (!selectedVariant) {
          alert('Por favor selecciona una variante');
          return;
        }

        // Aquí puedes agregar la lógica para añadir al carrito
        this.addToCart(productCard, selectedVariant.textContent);
      });
    });
  }

  setupWishlistButtons() {
    const wishlistButtons = document.querySelectorAll('.product-card__wishlist');
    
    wishlistButtons.forEach(button => {
      button.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        
        // Toggle wishlist state
        if (button.textContent === '♡') {
          button.textContent = '♥';
          button.style.color = '#ff0000';
        } else {
          button.textContent = '♡';
          button.style.color = '';
        }
      });
    });
  }

  addToCart(productCard, variant) {
    // Obtener información del producto
    const productTitle = productCard.querySelector('.product-card__title').textContent;
    const productPrice = productCard.querySelector('.current-price').textContent;
    
    console.log(`Agregando al carrito: ${productTitle} - Variante: ${variant} - Precio: ${productPrice}`);
    
    // Aquí integrarías con la API de Shopify Cart
    // fetch('/cart/add.js', { ... })
    
    // Feedback visual temporal
    const button = productCard.querySelector('.add-to-cart');
    const originalText = button.textContent;
    button.textContent = '¡Agregado!';
    button.style.background = '#28a745';
    
    setTimeout(() => {
      button.textContent = originalText;
      button.style.background = '';
    }, 2000);
  }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
  new FeaturedCollectionSplit();
});