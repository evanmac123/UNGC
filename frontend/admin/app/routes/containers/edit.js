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

  actions: {
    saveDraft(container) {
      container.save().then( () => {
        this.get('flashMessages').success('Draft Saved!');
      }, (error) => {
        if (error.errorThrown) {
          this.get('flashMessages').danger(error.statusText);
          throw error.toString();
        } else {
          this.get('flashMessages').danger('Validation Error!');
        }
      });
    },

    setDraftFromPayload(payload) {
      var container;

      if (!confirm('This will discard the current draft and revert to this previously published version.')) {
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
        this.get('flashMessages').success('Draft Published!');
        Payload.get({ container: container.get('id') }).then((records) => {
          records.toArray().reverse().forEach((record) => {
            if (payloads.findBy('id', record.get('id'))) {
              return;
            }

            payloads.insertAt(0, record);
          });
        });
      });
    },

    destroyModel(container) {
      if(confirm('This will destroy this page, it can not be undone')) {
        container.destroyModel().then( () => {
          this.transitionTo('containers.index');
        }, (error) => {
          let msg = error.errorThrown;
          if (error.jqXHR) {
            msg += ` - ${error.jqXHR.responseText}`;
          }
          alert(msg);
        });
      }
    }
  }
});
