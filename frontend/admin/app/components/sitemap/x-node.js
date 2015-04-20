import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',
  classNames: 'sitemap-x-node',

  mightDropAbove:  Ember.computed.equal('mightDrop', 'above'),
  mightDropBelow:  Ember.computed.equal('mightDrop', 'below'),
  mightDropInside: Ember.computed.equal('mightDrop', 'inside'),

  hasDraft: Ember.computed.oneWay('node.model.hasDraft'),

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
    },

    insert() {
      this.sendAction('onInsert', this.get('node'));
    },

    // Because recursive rendering
    subinsert(subnode) {
      this.sendAction('onInsert', subnode);
    },
    /*

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
    */

    loadContainer() {
      this.loadContainer();
    }
  },

  loadContainer() {
    this.get('node').load();
  }
});
