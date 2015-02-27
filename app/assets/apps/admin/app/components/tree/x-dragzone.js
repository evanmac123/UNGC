import Ember from 'ember';

export default Ember.Component.extend({
  tagName:           'span',
  isDraggable:       true,
  effect:            'move',
  attributeBindings: 'draggable',

  draggable: function() {
    return this.get('isDraggable') ? 'true' : null;
  }.property('isDraggable'),

  didStartDragging: function(event) {
    var effect;
    var nodeId = this.get('node.id');

    if (effect = this.get('effect')) {
      event.dataTransfer.effectAllowed = effect;
    }

    event.dataTransfer.setData('text', nodeId);

    this.set('for.isBeingDragged', true);
  }.on('dragStart'),

  didStopDragging: function() {
    this.set('for.isBeingDragged', false);
  }.on('dragEnd')
});
