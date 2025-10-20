/**
 * Collection Grid View Toggle
 * Manages view mode switching (1-col, 2-col, editorial) with localStorage persistence
 */

if (!customElements.get('collection-grid-view-toggle')) {
    class CollectionGridViewToggle extends HTMLElement {
        constructor() {
            super();
            console.log('🔨 CollectionGridViewToggle constructor called');
            this.init();
        }

        init() {
            console.log('🚀 CollectionGridViewToggle init() called');
            console.log('📍 this:', this);

            // The grid is the NEXT SIBLING element after the toggle
            this.grid = this.nextElementSibling;
            console.log('📍 Next sibling:', this.grid);

            // Verify it's the collection-grid
            if (!this.grid?.classList.contains('collection-grid')) {
                console.error('❌ Next sibling is not collection-grid! Found:', this.grid?.className);
                this.grid = null;
            }

            console.log('🎯 Found grid:', this.grid);

            if (!this.grid) {
                console.error('❌ Grid not found! Exiting init.');
                return;
            }

            // Apply the default/saved view FIRST
            this.applyDefaultView();

            // Then set up event listeners
            this.setupEventListeners();
        }

        applyDefaultView() {
            console.log('🔍 Applying default view...');

            // Check localStorage first
            if (!Shopify.designMode) {
                const savedView = localStorage.getItem('collection-grid-view');
                if (savedView) {
                    console.log('💾 Found saved view:', savedView);
                    const btn = this.querySelector(`[data-view="${savedView}"]`);
                    if (btn) {
                        this.updateGridView(savedView);
                        return;
                    }
                }
            }

            // Fall back to the button with aria-pressed="true"
            const activeBtn = this.querySelector('[aria-pressed="true"]');
            console.log('🔵 Active button:', activeBtn);
            console.log('🔵 Active button data-view:', activeBtn?.dataset.view);

            if (activeBtn) {
                const viewMode = activeBtn.dataset.view;
                console.log('📌 Using active button view:', viewMode);
                this.updateGridView(viewMode);
            } else {
                console.warn('⚠️ No active button found!');
            }
        }

        setupEventListeners() {
            console.log('🎮 Setting up event listeners');
            const buttons = this.querySelectorAll('.collection-grid__view-btn');
            console.log(`📌 Found ${buttons.length} buttons`);

            buttons.forEach(btn => {
                console.log(`➕ Adding listener to button:`, btn.dataset.view);
                btn.addEventListener('click', (e) => this.handleViewChange(e));
            });
        }

        handleViewChange(event) {
            const btn = event.currentTarget;
            const viewMode = btn.dataset.view;

            console.log('🖱️ Button clicked!');
            console.log('📌 View mode:', viewMode);
            console.log('📌 Button:', btn);

            // Update button states
            this.querySelectorAll('.collection-grid__view-btn').forEach(b => {
                b.setAttribute('aria-pressed', b === btn ? 'true' : 'false');
            });

            // Update grid class
            this.updateGridView(viewMode);

            // Persist preference if not in design mode
            if (!Shopify.designMode) {
                console.log('💾 Saving to localStorage:', viewMode);
                localStorage.setItem('collection-grid-view', viewMode);
            }
        }

        updateGridView(viewMode) {
            console.log('🎨 Updating grid view to:', viewMode);
            console.log('📊 Grid element:', this.grid);
            console.log('📊 Grid current classes:', this.grid.className);

            // Remove ALL existing view-* classes properly
            const classList = Array.from(this.grid.classList);
            console.log('📊 Current classList array:', classList);

            classList.forEach(cls => {
                if (cls.startsWith('view-')) {
                    console.log(`🗑️ Removing class: ${cls}`);
                    this.grid.classList.remove(cls);
                }
            });

            console.log('📊 After removal, classes:', Array.from(this.grid.classList));

            // Add new view class
            const newClass = `view-${viewMode}`;
            console.log(`➕ Adding class: ${newClass}`);
            this.grid.classList.add(newClass);

            console.log('✅ Grid classes updated:', this.grid.className);
            console.log('✅ Final classList:', Array.from(this.grid.classList));
        }
    }

    console.log('📝 Defining custom element: collection-grid-view-toggle');
    customElements.define('collection-grid-view-toggle', CollectionGridViewToggle);
    console.log('✅ Custom element defined');

    // Debug: Check if CSS is loaded and working
    setTimeout(() => {
        const toggle = document.querySelector('collection-grid-view-toggle');
        if (toggle && toggle.grid) {
            const computed = window.getComputedStyle(toggle.grid);
            console.log('🎨 COMPUTED GRID STYLES:');
            console.log('   grid-template-columns:', computed.gridTemplateColumns);
            console.log('   display:', computed.display);
            console.log('   width:', computed.width);
            console.log('   gap:', computed.gap);
            console.log('   Classes:', toggle.grid.className);

            // Check viewport width
            const vw = window.innerWidth;
            console.log(`📐 Viewport width: ${vw}px`);
            console.log(`🖥️  Desktop (≥1100px): ${vw >= 1100 ? '✅ YES' : '❌ NO'}`);
        }
    }, 100);
}
