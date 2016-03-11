import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',
  classNames: 'sitemap-x-node',

  mightDropAbove:  Ember.computed.equal('mightDrop', 'above'),
  mightDropBelow:  Ember.computed.equal('mightDrop', 'below'),
  mightDropInside: Ember.computed.equal('mightDrop', 'inside'),

  hasDraft: Ember.computed('node.model.hasDraft', 'node.model.draftPayloadId', function() {
    return this.get('node.model.hasDraft') && !Ember.isEmpty(this.get('node.model.draftPayloadId'));
  }),

  isPublished: Ember.computed('hasDraft', 'node.model.publicPayloadId', function() {
    return this.get('node.model.publicPayloadId') && !this.get('hasDraft');
  }),

  shortenedPublicPath: Ember.computed('node.model.publicPath', function() {
    var maxLength = 40;
    var fullPath = this.get('node.model.publicPath');
    var shortenedPath = fullPath;
    if(fullPath.length > maxLength) {
      var toTrim = fullPath.length - maxLength;
      shortenedPath = "..." + fullPath.slice(toTrim);
    }
    return shortenedPath;
  }),

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
  }
});
