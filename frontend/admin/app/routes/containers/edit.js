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
      container.save().then( () => {
        Ember.get(this, 'flashMessages').success('Draft Saved!');
      }, (error) => {
        if (error.status) {
          Ember.get(this, 'flashMessages').danger(error.statusText);
          throw error.toString();
        } else {
          Ember.get(this, 'flashMessages').danger('Validation Error!');
        }
      });
    },

    setDraftFromPayload(payload) {
      var container;

      if (!confirm('This will discard the current draft and revert the from to this previously published version.')) {
        return;
      }

      container = this.modelFor('containers.edit').container;

      container.setPropertiesFromJSON({
        data: payload.asJSON().data
      });
    },

    publish(container) {
      var payloads = this.modelFor('containers.edit').payloads;

      if (!confirm('Are you sure you want to publish this page?')) {
        return;
      }

      container.publish().then(() => {
        Payload.get({ container: container.get('id') }).then((records) => {
          records.toArray().reverse().forEach((record) => {
            if (payloads.findBy('id', record.get('id'))) {
              return;
            }

            payloads.insertAt(0, record);
          });
        });
      });
    }
  }
});
