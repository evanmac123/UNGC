import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params) {
    return this.store.find('image',params.image_id);
  },

  actions: {
    back() {
      this.transitionTo('images.index');
    },

    save(image) {
      image.save().then( () => {
        this.get('flashMessages').success('Image Saved!');
      }, (error) => {
        this.get('flashMessages').danger(error.statusText);
        throw error.toString();
      });
    },
  }

});
