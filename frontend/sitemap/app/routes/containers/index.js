import Ember     from 'ember';
// import Container from 'sitemap/models/container';
import Sitemap   from 'sitemap/lib/sitemap/tree';

export default Ember.Route.extend({
  model: function() {
    return Sitemap.create();
  },

  afterModel(sitemap) {
    sitemap.load();
  },

  actions: {
    moveContainer(action) {
      var sitemap     = this.modelFor('containers.index');
      var source      = sitemap.containerForId(action.sourceId);
      var destination = sitemap.containerForId(action.destId);

      sitemap.moveContainer(source, destination, action.position).catch( (modelWithErrors) => {
        this.get('flashMessages').danger(modelWithErrors.errors.get('firstObject.detail'));
      });
    },

    addContainer(parentContainer) {
      if (parentContainer) {
        this.transitionTo('containers.new', parentContainer.get('id'));
      } else {
        this.transitionTo('containers.new', 'root');
      }
    }
  }
});
