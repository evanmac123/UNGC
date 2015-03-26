import Ember     from 'ember';
import Container from 'admin/models/container';
import Payload   from 'admin/models/payload';

export default Ember.Route.extend({
  model(params) {
    return Ember.RSVP.hash({
      container: Container.get(params.container_id),
      payloads: Payload.get({ container: params.container_id })
    });
  },

  renderTemplate() {
    this.render('containers/form');
  },

  actions: {
    saveDraft(container) {
      container.save();
    },

    publish(container) {
      if (!confirm('Are you sure you want to publish this page?')) {
        return;
      }

      container.publish();
    }
  }
});
