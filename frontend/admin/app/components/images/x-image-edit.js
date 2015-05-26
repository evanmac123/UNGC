import Ember from 'ember';

export default Ember.Component.extend({
  //default actions
  back: 'back',

  actions: {
    save(image) {
      image.save();
    },
    back() {
      this.sendAction('back');
    }
  }
});
