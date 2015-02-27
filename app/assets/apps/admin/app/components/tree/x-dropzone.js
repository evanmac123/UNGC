import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'span',
  isDroppable: true,
  attributeBindings: 'droppable',
  classNames: 'tree-x-dropzone',
  tree: Ember.computed.reads('parentView.tree'),
  node: null,
  position: null,

  classNameBindings: [
    'hasContent:drop-container:drop-inline',
    'position',
    'isActive:active:inactive'
  ],

  hasContent: function() {
    return this.get('template') ? true : false;
  }.property('template'),

  droppable: function() {
    return this.get('isDroppable') ? 'true' : null;
  }.property('isDroppable'),

  didStartDraggableEncounter: function(event) {
    event.preventDefault();
    this.set('isActive', true);
  }.on('dragOver'),

  didFinishDraggableEncounter: function() {
    this.set('isActive', false);
  }.on('dragLeave'),

  didAcceptDroppable: function(event) {
    var srcId = event.dataTransfer.getData('text');

    this.set('isActive', false);
    this.get('tree').send('move',
      srcId,
      this.get('position'),
      this.get('node.id')
    );
  }.on('drop')
});
