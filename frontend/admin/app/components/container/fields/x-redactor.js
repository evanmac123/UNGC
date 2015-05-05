import Ember from 'ember';

export default Ember.Component.extend({
  formatting: ['p', 'h2', 'h3', 'h4', 'h5'],
  buttons: ['html', 'formatting', 'bold', 'italic', 'deleted',
    'unorderedlist', 'orderedlist', 'outdent', 'indent',
    'image', 'link', 'alignment', 'horizontalrule'],

  height: null,
  _minHeight: '300px',

  minHeight: Ember.computed('field.height', function() {
    return this.get('field.height') || this.get('_minHeight');
  })

});
