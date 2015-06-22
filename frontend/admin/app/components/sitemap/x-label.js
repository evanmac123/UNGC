import Ember from 'ember';

const DROP_OUTSIDE_THRESHOLD = 0.28;
const ABOVE  = 'above';
const BELOW  = 'below';
const INSIDE = 'inside';

export default Ember.Component.extend({
  classNames: 'sitemap-x-label',
  isDroppable: true,
  isDraggable: Ember.computed.oneWay('node.model.draggable'),

  attributeBindings: [
    'isDroppable:droppable',
    'isDraggable:draggable'
  ],

  mightDropNode: Ember.on('dragOver', function(event) {
    var y         = event.originalEvent.y;
    var h         = this.$().height();
    var top       = this.$().offset().top - Ember.$('body').scrollTop();
    var bot       = top + h;
    var insRng    = h * DROP_OUTSIDE_THRESHOLD;
    var pxFromTop = y - top;
    var pxFromBot = bot - y;
    var position;

    event.preventDefault();

    if (pxFromTop <= insRng) {
      position = ABOVE;
    } else if (pxFromBot <= insRng) {
      position = BELOW;
    } else {
      position = INSIDE;
    }

    this.set('mightDropPosition', position);
    this.sendAction('onDragOver', position);
  }),

  wontDropNode: Ember.on('dragLeave', function() {
    this.sendAction('onDragLeave');
    this.set('mightDropPosition', null);
  }),

  didDropNode: Ember.on('drop', function(event) {
    var srcId = event.dataTransfer.getData('text/x-container-id');

    this.sendAction('onDrop', {
      sourceId: parseInt(srcId, 10),
      destId: this.get('node.modelId'),
      position: this.get('mightDropPosition')
    });

    this.set('mightDropPosition', null);
  }),

  startedDragging: Ember.on('dragStart', function(event) {
    var id = this.get('node.modelId');

    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/x-container-id', id);

    this.set('isBeingDragged', true);
  }),

  stoppedDragging: Ember.on('dragEnd', function() {
    this.set('isBeingDragged', false);
  })
});
