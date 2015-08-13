import Ember     from 'ember';
import Container from 'sitemap/models/container';
import Layout from 'sitemap/models/layout';

export default Ember.Route.extend({
  model(params) {
    return Ember.RSVP.hash({
      container: Container.get(params.container_id),
      layouts:   Layout.get()
    });
  },
  afterModel(model) {
    let currentLayout = model.container.get('layout');
    let layout = model.layouts.find((l) => {
      return l.id === currentLayout;
    });

    model.container.set('layoutRecord', layout);
  },

  actions: {
    dismiss(model) {
      this.transitionTo('containers.edit', model);
    },

    saveContainer(model) {
      model.set('layout', model.get('layoutRecord.id'));
      model.save({ without: ['data'] }).then((container) => {
        this.transitionTo('containers.edit', container.get('id'));
      }, (error) => {
        if (error.errorThrown) {
          this.get('flashMessages').danger(error.statusText);
          throw error.toString();
        } else {
          this.get('flashMessages').danger('Validation Error!');
        }
      });
    }
  }
});
