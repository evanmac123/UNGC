import Model from 'admin/lib/model';

var Payload = Model.extend();

Payload.type = 'payload';
Payload.path = '/redesign/admin/api/payloads';

Payload.attributes = [
  'data'
];

export default Payload;