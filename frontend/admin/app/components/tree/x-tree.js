import Ember from 'ember';

export default Ember.Component.extend({
  classNames: 'tree-x-tree',

  setTree: function() {
    if (this.get('subtree')) {
      return;
    }

    this.set('tree', this);
  }.on('init'),

  actions: {
    move: function(srcId, position, destId) {
      this.sendAction('move', srcId, position, destId);
    }
  }
});
