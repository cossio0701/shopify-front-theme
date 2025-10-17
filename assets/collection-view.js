if (!customElements.get('collection-view')) {
  class CollectionView extends HTMLElement {
    constructor() {
      super();

      this.setInitialStates();

      this.addEventListener('click', e => {
        // Buscar el botón más cercano (en caso de que clickee en SVG u otro elemento dentro)
        const btnTarget = e.target.closest('.js-view-btn');

        if (!btnTarget) {
          console.log('❌ No es un botón, retornando');
          return;
        }

        const productGrid = document.querySelector('.collection__grid');
        console.log('🔍 Product grid encontrado:', productGrid);

        if (!productGrid) {
          console.log('❌ No se encontró product grid');
          return;
        }

        const btnSelected = this.querySelector('.js-view-btn[aria-pressed="true"]');
        console.log('📌 Botón target:', btnTarget.dataset.view);
        console.log('📌 Botón seleccionado actualmente:', btnSelected?.dataset.view);

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
      console.log('🚀 CollectionView inicializando...');
      const storedView = localStorage.getItem('collection-view-style');
      console.log('💾 Vista guardada en localStorage:', storedView);

      if (Shopify.designMode || !storedView) {
        console.log('⏭️  Saltando inicialización (designMode o sin vista guardada)');
        return;
      }

      const productGrid = document.querySelector('.collection__grid');
      console.log('🔍 Product grid encontrado:', productGrid);

      if (!productGrid) {
        console.log('❌ No se encontró product grid en setInitialStates');
        return;
      }

      const newBtn = this.querySelector(
        `.js-view-btn[data-view="${storedView}"]`
      );
      const btnSelected = this.querySelector('.js-view-btn[aria-pressed="true"]');
      console.log('🔍 Botón a aplicar:', newBtn?.dataset.view);
      console.log('🔍 Botón seleccionado actual:', btnSelected?.dataset.view);

      if (newBtn && btnSelected && newBtn !== btnSelected) {
        console.log('✅ Aplicando vista guardada:', storedView);
        this.updateStates(newBtn, btnSelected, productGrid);
      }
    }

    updateStates(newBtn, initialBtn, productGrid) {
      console.log('🔄 updateStates llamado');
      console.log('Grid antes:', productGrid.className);
      
      if (initialBtn) {
        initialBtn.setAttribute('aria-pressed', 'false');
      }
      newBtn.setAttribute('aria-pressed', 'true');
      
      const viewStyle = newBtn.dataset.view;
      console.log('📐 Aplicando vista:', viewStyle);
      productGrid.dataset.viewStyle = viewStyle;
      
      // Remover clases view-* existentes
      const oldClass = productGrid.className;
      productGrid.className = productGrid.className.replace(/view-\w+/g, '');
      console.log('Después de remover clases:', productGrid.className);
      
      productGrid.classList.add(`view-${viewStyle}`);
      console.log('✅ Clases aplicadas al grid:', productGrid.className);
      console.log('Grid después:', productGrid.className);

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
