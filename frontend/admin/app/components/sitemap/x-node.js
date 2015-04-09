import Ember from 'ember';

const STORE_KEY = 'sitemap';

export default Ember.Component.extend({
  tagName: 'li',
  classNames: 'sitemap-x-node',

  mightDropAbove:  Ember.computed.equal('mightDrop', 'above'),
  mightDropBelow:  Ember.computed.equal('mightDrop', 'below'),
  mightDropInside: Ember.computed.equal('mightDrop', 'inside'),

  classNameBindings: [
    'isOpen:open:closed',
    'isBeingDragged:being-dragged',
    'mightDropAbove',
    'mightDropBelow',
    'mightDropInside',
    'node.isLoading:loading'
  ],

  actions: {
    toggle() {
      if (this.get('isOpen')) {
        this.set('isOpen', false);
      } else {
        this.set('isOpen', true);
        this.send('loadContainer');
      }

      this.saveState();
    },

    insert() {
      this.sendAction('insert', this.get('node'));
    },

    // Because recursive rendering
    subinsert(subnode) {
      this.sendAction('insert', subnode);
    },

    onMightDropNode(position) {
      this.set('mightDrop', position);
    },

    onWontDropNode() {
      this.set('mightDrop', null);
    },

    onDroppedNode(event) {
      this.set('mightDrop', null);
      this.sendAction('onMove', event);
    },

    loadContainer() {
      this.loadContainer();
    }
  },

  loadContainer() {
    this.get('node').load();
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
