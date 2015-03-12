import Ember from 'ember';

const DROP_OUTSIDE_THRESHOLD = 0.28;
const ABOVE  = 'above';
const BELOW  = 'below';
const INSIDE = 'inside';

export default Ember.Component.extend({
  tagName: 'span',
  isDroppable: true,

  attributeBindings: [
    'isDroppable:droppable'
  ],

  mightDropNode: function(event) {
    event.preventDefault();

    var y         = event.originalEvent.y;
    var h         = this.$().height();
    var top       = this.$().offset().top;
    var bot       = top + h;
    var insRng    = h * DROP_OUTSIDE_THRESHOLD;
    var pxFromTop = y - top;
    var pxFromBot = bot - y;
    var position;

    if (pxFromTop <= insRng) {
      position = ABOVE;
    } else if (pxFromBot <= insRng) {
      position = BELOW;
    } else {
      position = INSIDE;
    }

    this.set('mightDrop', position);
    this.sendAction('dragOver', position);
  }.on('dragOver'),

  wontDropNode: function() {
    this.set('mightDrop', null);
    this.sendAction('dragLeave');
  }.on('dragLeave'),

  didDropNode: function(event) {
    var srcId = event.dataTransfer.getData('text/x-node-id');

    this.sendAction('drop', {
      sourceId: srcId,
      destId: this.get('node.id'),
      position: this.get('mightDrop')
    });

    this.set('mightDrop', null);
  }.on('drop')
});
