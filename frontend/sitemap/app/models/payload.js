import Model from 'sitemap/lib/model';

var Payload = Model.extend();

Payload.type = 'payload';
Payload.path = '/sitemap/api/payloads';

Payload.attributes = [
  'data'
];

export default Payload;