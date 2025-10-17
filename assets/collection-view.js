if (!customElements.get('collection-view')) {
  class CollectionView extends HTMLElement {
    constructor() {
      super();

      this.setInitialStates();

      this.addEventListener('click', e => {
        const isBtn = e.target.classList.contains('js-view-btn');

        if (!isBtn) {
          return;
        }

        const productGrid = document.querySelector('#product-grid');

        if (!productGrid) {
          return;
        }

        const btnTarget = e.target;
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

      const productGrid = document.querySelector('#product-grid');

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
