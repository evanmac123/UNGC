import Ember from 'ember';
import request from 'ic-ajax';

export default Ember.Component.extend({
  //default actions
  uploadError: null,
  isSaving: false,
  file: null,
  actions: {
    submit: function() {
      var file = this.get("file");
      if (file && file.length > 0) {
        this.processFile(file[0]);
      }
    }
  },

  hasErrors: Ember.computed.or('field.hasErrors', 'uploadError'),

  processFile: function(file) {

    const filename = file.name;
    var promise = this.getSignedUrl(filename);

    this.set('uploadError', null);
    this.set("isSaving", true);
    promise.then(this.performUpload.bind(this)).then( () => {
      const url =  this.get('url');
      this.set('field.value', url);
      this.saveUploadedImage(url, filename);
    }).catch( /* errorResponse */ () => {
      this.set('uploadError', 'Invalid file');
    }).finally( () => {
      this.set("isSaving", false);
    });
  },

  performUpload: function(upload) {
    var file = this.get('file')[0];
    var controller = this;
    var receivedResolver;
    var receivedRejector;

    this.set('url', upload.base_url);

    var receivedPromise = new Ember.RSVP.Promise( (resolve, reject) => {
      receivedResolver = resolve;
      receivedRejector = reject;
    });

    new Ember.RSVP.Promise( (resolve, reject) => {
      Ember.$.ajax(upload.signed_url, {
        type:        'put',
        data:        file,
        crossDomain: true,
        processData: false,
        contentType: upload.mime,
        beforeSend:  null,
        headers: {
          'x-amz-acl': 'public-read'
        },

        // For a reason I'm not able to investigate at the moment, jqXHR always
        // rejects onload with the custom progress listener below.
        // TODO: Fix this so that it will work idiomatically.
        xhr: function() {
          var xhr = Ember.$.ajaxSettings.xhr();

          controller.set('xhr', xhr.upload);

          xhr.upload.addEventListener('progress', function(event) {
            Ember.run(function() {
              if (event.lengthComputable) {
                controller.set('progress', (event.loaded / event.total) * 100);
              }
            });
          });

          xhr.upload.addEventListener('load', function() {
            var http = this;

            Ember.run(function() {
              resolve(http);
            });
          });

          xhr.addEventListener('load', function() {
            var http = this;

            Ember.run(function() {
              if (http.status === 200) {
                receivedResolver(http);
              } else {
                receivedRejector(http);
              }
            });
          });

          xhr.upload.addEventListener('error', function() {
            var http = this;

            Ember.run(function() {
              reject(http);
            });
          });

          return xhr;
        }
      });
    });
    return receivedPromise;
  },

  getSignedUrl: function(filename) {
    return request({
      type: "POST",
      url: "/sitemap/api/images/signed_url",
      data: { filename: filename }
    });
  },

  saveUploadedImage(url, filename) {
    return request({
      type: "POST",
      url: "/sitemap/api/images",
      data: {
        image: {
          url: url,
          filename: filename
        }
      }
    });
  }
});


