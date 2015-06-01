import Ember from 'ember';

export default Ember.Component.extend({
  //default actions
  back: 'back',
  save: 'save',

  actions: {
    save(image) {
      this.sendAction('save', image);
    },
    back() {
      this.sendAction('back');
    }
  }
});
