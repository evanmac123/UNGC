import Ember from 'ember';

const STORE_KEY = 'sitemap:';

export default Ember.Component.extend({
  tagName: 'li',
  className: 'sitemap-x-node',

  actions: {
    toggle() {
      if (this.get('isOpen')) {
        this.set('isOpen', false);
      } else {
        this.set('isOpen', true);
      }

      this.saveState();
    }
  },

  saveState() {
    var id    = this.get('node.modelId');
    var store = this.getStore();

    if (!id) {
      return;
    }

    store[id] = {
      isOpen: this.get('isOpen')
    };

    this.setStore(store);
  },

  loadState: function() {
    var id = this.get('node.modelId');
    var store = this.getStore();
    var state;

    if (!id) {
      return;
    }

    if (state = store[id]) {
      this.set('isOpen', state.isOpen ? true : false);
    }
  }.on('init'),

  getStore() {
    var json;
    var store;

    if (!localStorage) {
      return;
    }

    if (json = localStorage.getItem(STORE_KEY)) {
      store = JSON.parse(json);
    } else {
      store = {};
    }

    return store;
  },

  setStore(store) {
    if (!localStorage) {
      return;
    }

    localStorage.setItem(STORE_KEY, JSON.stringify(store));
  }
});
