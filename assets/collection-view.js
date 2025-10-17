if (!customElements.get('collection-view')) {
  class CollectionView extends HTMLElement {
    constructor() {
      super();

      this.setInitialStates();

      this.addEventListener('click', e => {
        // Buscar el botón más cercano (en caso de que clickee en SVG u otro elemento dentro)
        const btnTarget = e.target.closest('.js-view-btn');

        if (!btnTarget) {
          return;
        }

        const productGrid = document.querySelector('.collection__grid');

        if (!productGrid) {
          return;
        }

        const btnSelected = this.querySelector('.js-view-btn[aria-pressed="true"]');

        this.updateStates(btnTarget, btnSelected, productGrid);

        if (Shopify.designMode) {
          return;
        }

        localStorage.setItem(
          'collection-view-style',
          btnTarget.dataset.view
        );
      });
    }

    setInitialStates() {
      const storedView = localStorage.getItem('collection-view-style');

      if (Shopify.designMode || !storedView) {
        return;
      }

      const productGrid = document.querySelector('.collection__grid');

      if (!productGrid) {
        return;
      }

      const newBtn = this.querySelector(
        `.js-view-btn[data-view="${storedView}"]`
      );
      const btnSelected = this.querySelector('.js-view-btn[aria-pressed="true"]');

      if (newBtn && btnSelected && newBtn !== btnSelected) {
        this.updateStates(newBtn, btnSelected, productGrid);
      }
    }

    updateStates(newBtn, initialBtn, productGrid) {
      if (initialBtn) {
        initialBtn.setAttribute('aria-pressed', 'false');
      }
      newBtn.setAttribute('aria-pressed', 'true');
      
      const viewStyle = newBtn.dataset.view;
      productGrid.dataset.viewStyle = viewStyle;
      
      // Remover clases view-* existentes
      productGrid.className = productGrid.className.replace(/view-\w+/g, '');
      productGrid.classList.add(`view-${viewStyle}`);

      this.updateGridItems();
    }

    updateGridItems() {
      const collectionLoadMore = document.querySelector(
        'collection-load-more'
      );

      if (!collectionLoadMore) {
        return;
      }

      collectionLoadMore.toggleProductsVisibility();
    }
  }

  customElements.define('collection-view', CollectionView);
}
