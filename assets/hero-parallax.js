// hero-parallax.js - Versión corregida para mostrar imágenes correctamente

class HeroParallax {
  constructor() {
    this.heroBanner = document.querySelector('.hero-banner--parallax');
    this.heroSection = document.querySelector('.section-hero-banner');
    this.heroInner = null;
    this.heroContent = null;
    this.heroMedia = null;
    
    this.isEnabled = false;
    this.isMobileEnabled = false;
    this.intensity = 'medium';
    this.scrollPosition = 0;
    this.sectionHeight = 0;
    this.windowHeight = 0;
    this.isScrolling = false;
    this.rafId = null;
    this.isReady = false;
    
    // Configuración de intensidades
    this.intensitySettings = {
      light: {
        contentSpeed: 0.2,
        mediaSpeed: 0.05,
        opacitySpeed: 0.6
      },
      medium: {
        contentSpeed: 0.4,
        mediaSpeed: 0.1,
        opacitySpeed: 0.8
      },
      strong: {
        contentSpeed: 0.6,
        mediaSpeed: 0.15,
        opacitySpeed: 1.0
      }
    };
    
    this.init();
  }

  init() {
    if (!this.heroBanner) {
      console.log('HeroParallax: No se encontró .hero-banner--parallax');
      return;
    }
    
    // Obtener configuración desde los atributos data
    this.isEnabled = this.heroBanner.dataset.parallaxEnabled === 'true';
    this.isMobileEnabled = this.heroBanner.dataset.parallaxMobile === 'true';
    this.intensity = this.heroBanner.dataset.parallaxIntensity || 'medium';
    
    console.log('HeroParallax: Configuración obtenida:', {
      enabled: this.isEnabled,
      mobile: this.isMobileEnabled,
      intensity: this.intensity
    });
    
    if (!this.isEnabled) {
      console.log('HeroParallax: Efecto deshabilitado');
      return;
    }
    
    // Esperar a que las imágenes estén cargadas
    this.waitForImagesAndInit();
  }

  waitForImagesAndInit() {
    const images = this.heroBanner.querySelectorAll('img');
    const videos = this.heroBanner.querySelectorAll('video');
    
    let loadedCount = 0;
    const totalMedia = images.length + videos.length;
    
    const checkReady = () => {
      loadedCount++;
      if (loadedCount >= totalMedia || totalMedia === 0) {
        this.initParallax();
      }
    };
    
    // Si no hay media, inicializar inmediatamente
    if (totalMedia === 0) {
      setTimeout(() => this.initParallax(), 100);
      return;
    }
    
    // Esperar a que las imágenes carguen
    images.forEach(img => {
      if (img.complete) {
        checkReady();
      } else {
        img.addEventListener('load', checkReady);
        img.addEventListener('error', checkReady);
      }
    });
    
    // Esperar a que los videos estén listos
    videos.forEach(video => {
      if (video.readyState >= 2) {
        checkReady();
      } else {
        video.addEventListener('loadeddata', checkReady);
        video.addEventListener('error', checkReady);
      }
    });
    
    // Timeout de seguridad
    setTimeout(() => {
      if (!this.isReady) {
        console.log('HeroParallax: Timeout - inicializando sin esperar media');
        this.initParallax();
      }
    }, 2000);
  }

  initParallax() {
    if (this.isReady) return;
    
    console.log('HeroParallax: Inicializando parallax...');
    
    this.setupElements();
    this.ensureImageVisibility();
    this.calculateDimensions();
    this.bindEvents();
    this.checkDevice();
    
    // Agregar clase para indicar que el parallax está activo
    this.heroBanner.classList.add('parallax-active');
    this.isReady = true;
    
    console.log('HeroParallax: Parallax inicializado correctamente');
  }

  setupElements() {
    this.heroInner = this.heroBanner.querySelector('.hero__inner');
    this.heroContent = this.heroBanner.querySelector('.hero__content');
    this.heroMedia = this.heroBanner.querySelector('.hero__media');
    
    // Si hay múltiples slides, obtener el activo
    const activeSlide = this.heroBanner.querySelector('.swiper-slide-active');
    if (activeSlide) {
      this.heroContent = activeSlide.querySelector('.hero__content');
      this.heroMedia = activeSlide.querySelector('.hero__media');
    }
    
    console.log('HeroParallax: Elementos configurados:', {
      heroInner: !!this.heroInner,
      heroContent: !!this.heroContent,
      heroMedia: !!this.heroMedia
    });
  }

  ensureImageVisibility() {
    // Asegurar que las imágenes sean visibles
    if (this.heroMedia) {
      // Aplicar estilos para garantizar visibilidad
      this.heroMedia.style.display = 'block';
      this.heroMedia.style.position = 'absolute';
      this.heroMedia.style.top = '0';
      this.heroMedia.style.left = '0';
      this.heroMedia.style.width = '100%';
      this.heroMedia.style.height = '100%';
      this.heroMedia.style.zIndex = '1';
      
      // Encontrar y configurar las imágenes dentro del media
      const images = this.heroMedia.querySelectorAll('img');
      images.forEach(img => {
        img.style.width = '100%';
        img.style.height = '100%';
        img.style.objectFit = 'cover';
        img.style.display = 'block';
      });
      
      // Configurar videos
      const videos = this.heroMedia.querySelectorAll('video');
      videos.forEach(video => {
        video.style.width = '100%';
        video.style.height = '100%';
        video.style.objectFit = 'cover';
        video.style.display = 'block';
      });
    }
    
    // Asegurar que el contenido tenga z-index alto
    if (this.heroContent) {
      this.heroContent.style.position = 'relative';
      this.heroContent.style.zIndex = '10';
    }
  }

  calculateDimensions() {
    if (!this.heroSection) return;
    
    this.sectionHeight = this.heroSection.offsetHeight;
    this.windowHeight = window.innerHeight;
    
    // Asegurar altura mínima
    if (this.sectionHeight < this.windowHeight) {
      this.heroBanner.style.minHeight = this.windowHeight + 'px';
      this.sectionHeight = this.windowHeight;
    }
    
    // Ajustar el margen negativo del siguiente elemento
    const nextElement = this.heroSection.nextElementSibling;
    if (nextElement && this.isActive()) {
      nextElement.style.marginTop = `-${this.sectionHeight}px`;
      nextElement.style.paddingTop = '2rem';
      nextElement.style.position = 'relative';
      nextElement.style.zIndex = '200';
      nextElement.style.background = 'white';
    }
    
    console.log('HeroParallax: Dimensiones calculadas:', {
      sectionHeight: this.sectionHeight,
      windowHeight: this.windowHeight
    });
  }

  bindEvents() {
    // Optimizar scroll con requestAnimationFrame
    let ticking = false;
    
    const handleScroll = () => {
      if (!ticking && this.isActive() && this.isReady) {
        requestAnimationFrame(() => {
          this.updateParallax();
          ticking = false;
        });
        ticking = true;
      }
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    
    // Recalcular dimensiones en resize
    window.addEventListener('resize', () => {
      this.checkDevice();
      setTimeout(() => {
        this.calculateDimensions();
        this.ensureImageVisibility();
      }, 100);
    });

    // Manejar cambios de slide si hay swiper
    if (this.heroBanner.querySelector('.swiper')) {
      const swiper = this.heroBanner.querySelector('.swiper');
      
      swiper.addEventListener('slideChange', () => {
        setTimeout(() => {
          this.setupElements();
          this.ensureImageVisibility();
          this.calculateDimensions();
        }, 100);
      });
    }

    // Intersection Observer para optimizar rendimiento
    this.setupIntersectionObserver();
  }

  setupIntersectionObserver() {
    const options = {
      root: null,
      rootMargin: '50px',
      threshold: 0
    };

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.heroBanner.classList.add('in-viewport');
        } else {
          this.heroBanner.classList.remove('in-viewport');
        }
      });
    }, options);

    this.observer.observe(this.heroBanner);
  }

  updateParallax() {
    if (!this.heroBanner.classList.contains('in-viewport')) return;
    
    this.scrollPosition = window.pageYOffset;
    
    // Calcular progreso del scroll
    const progress = Math.min(this.scrollPosition / this.sectionHeight, 1);
    const settings = this.intensitySettings[this.intensity];
    
    // Aplicar transformaciones según el progreso
    this.applyContentTransform(progress, settings);
    this.applyMediaTransform(progress, settings);
    this.applyMaskEffect(progress);
    
    // Agregar/quitar clase de scrolling
    if (this.scrollPosition > 50 && !this.isScrolling) {
      this.heroBanner.classList.add('hero-banner--scrolling');
      this.isScrolling = true;
    } else if (this.scrollPosition <= 50 && this.isScrolling) {
      this.heroBanner.classList.remove('hero-banner--scrolling');
      this.isScrolling = false;
    }
  }

  applyContentTransform(progress, settings) {
    if (!this.heroContent) return;
    
    const translateY = progress * 40 * settings.contentSpeed;
    const opacity = Math.max(1 - (progress * settings.opacitySpeed), 0);
    
    this.heroContent.style.transform = `translateY(${translateY}px)`;
    this.heroContent.style.opacity = opacity;
  }

  applyMediaTransform(progress, settings) {
    if (!this.heroMedia) return;
    
    const translateY = progress * 20 * settings.mediaSpeed;
    const scale = 1 + (progress * 0.05); // Reducir el scale para evitar problemas
    
    this.heroMedia.style.transform = `translateY(${translateY}px) scale(${scale})`;
  }

  applyMaskEffect(progress) {
    // Aplicar clip-path de manera más conservadora
    const clipProgress = Math.max(0, Math.min(1, (progress - 0.4) * 2));
    
    if (clipProgress > 0.1) {
      const clipPercentage = 100 - (clipProgress * 20); // Reducir el clip máximo
      this.heroBanner.style.clipPath = `inset(0 0 ${100 - clipPercentage}% 0)`;
    } else {
      this.heroBanner.style.clipPath = 'none';
    }
  }

  checkDevice() {
    const isMobile = window.innerWidth < 768;
    
    if (isMobile && !this.isMobileEnabled) {
      this.disable();
    } else if (!isMobile && this.isEnabled) {
      this.enable();
    }
  }

  isActive() {
    const isMobile = window.innerWidth < 768;
    return this.isEnabled && this.isReady && (!isMobile || this.isMobileEnabled);
  }

  enable() {
    if (!this.heroBanner) return;
    
    this.heroBanner.classList.add('parallax-active');
    this.ensureImageVisibility();
    this.calculateDimensions();
  }

  disable() {
    if (!this.heroBanner) return;
    
    this.heroBanner.classList.remove('parallax-active', 'hero-banner--scrolling');
    
    // Resetear estilos
    if (this.heroContent) {
      this.heroContent.style.transform = 'none';
      this.heroContent.style.opacity = '1';
    }
    
    if (this.heroMedia) {
      this.heroMedia.style.transform = 'none';
    }
    
    this.heroBanner.style.clipPath = 'none';
    this.heroBanner.style.minHeight = '';
    
    // Resetear el siguiente elemento
    const nextElement = this.heroSection?.nextElementSibling;
    if (nextElement) {
      nextElement.style.marginTop = '0';
      nextElement.style.paddingTop = '0';
    }
  }

  destroy() {
    this.disable();
    
    if (this.observer) {
      this.observer.disconnect();
    }
    
    if (this.rafId) {
      cancelAnimationFrame(this.rafId);
    }
    
    this.isReady = false;
  }
}

// Función de inicialización mejorada
function initHeroParallax() {
  // Evitar múltiples inicializaciones
  if (window.heroParallaxInitialized) return;
  
  try {
    // Agregar clase debug si está en desarrollo
    if (window.location.hostname === 'localhost' || window.location.hostname.includes('myshopify.com')) {
      document.body.classList.add('parallax-debug');
    }
    
    window.heroParallaxInstance = new HeroParallax();
    window.heroParallaxInitialized = true;
    
    console.log('Hero Parallax initialized successfully');
  } catch (error) {
    console.error('Error initializing Hero Parallax:', error);
  }
}

// Múltiples puntos de inicialización para mayor compatibilidad
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initHeroParallax);
} else {
  initHeroParallax();
}

// Inicializar también en load para asegurar que todo esté cargado
window.addEventListener('load', () => {
  if (!window.heroParallaxInitialized) {
    initHeroParallax();
  }
});

// Reinicializar en cambios de página SPA
window.addEventListener('popstate', () => {
  setTimeout(() => {
    if (window.heroParallaxInstance) {
      window.heroParallaxInstance.destroy();
      window.heroParallaxInitialized = false;
    }
    initHeroParallax();
  }, 100);
});

// Exponer para debugging
window.HeroParallax = HeroParallax;