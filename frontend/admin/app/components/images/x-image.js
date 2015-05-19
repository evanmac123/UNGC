import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  isDisabled: false,

  actions: {
    destroy(image) {
      this.set('isDisabled', true);
      image.destroyRecord();
    }
  }
});

