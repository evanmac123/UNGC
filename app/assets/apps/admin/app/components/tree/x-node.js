import Ember from 'ember';

const STORE_KEY_PREFIX  = 'ui-tree';
const STORE_KEY_DEFAULT = 'nodestates';

export default Ember.Component.extend({
  classNames: 'tree-x-node',
  isDraggable: true,

  attributeBindings: [
    'isDraggable:draggable'
  ],

  mightDropAbove:  Ember.computed.equal('mightDrop', 'above'),
  mightDropBelow:  Ember.computed.equal('mightDrop', 'below'),
  mightDropInside: Ember.computed.equal('mightDrop', 'inside'),

  classNameBindings: [
    'isOpen:open:closed',
    'isBeingDragged:being-dragged',
    'mightDropAbove',
    'mightDropBelow',
    'mightDropInside'
  ],

  actions: {
    toggle() {
      if (this.get('isOpen')) {
        this.set('isOpen', false);
      } else {
        this.set('isOpen', true);
      }

      this.saveState();
    },

    mightDropNode(position) {
      this.set('mightDrop', position);
    },

    wontDropNode() {
      this.set('mightDrop', null);
    },

    droppedNode(event) {
      this.set('mightDrop', null);
      this.get('tree').send('move', event);
    }
  },

  startedDragging: function(event) {
    var nodeId = this.get('node.id');

    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/x-node-id', nodeId);

    this.set('isBeingDragged', true);
  }.on('dragStart'),

  stoppedDragging: function() {
    this.set('isBeingDragged', false);
  }.on('dragEnd'),

  storeKey: Ember.computed('ns', function() {
    return STORE_KEY_PREFIX + ':' + (this.get('ns') || STORE_KEY_DEFAULT);
  }),

  saveState() {
    var id    = this.get('node.id');
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
    var id = this.get('node.id');
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
    var storeKey = this.get('storeKey');
    var json;
    var store;

    if (!localStorage) {
      return;
    }

    if (json = localStorage.getItem(storeKey)) {
      store = JSON.parse(json);
    } else {
      store = {};
    }

    return store;
  },

  setStore(store) {
    var storeKey = this.get('storeKey');

    if (!localStorage) {
      return;
    }

    localStorage.setItem(storeKey, JSON.stringify(store));
  }
});
