import 'package:abey_wallet/model/identity_model.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class EDrawer {

}

class ELanguage {

}

class ECurrency {

}

class UpdateIdentity {
  IdentityModel identityModel;

  UpdateIdentity(this.identityModel);
}

class UpdateBalance {

}

class UpdateChain {

}

class UpdateDrawer {

}

class UpdateKyf {

}

class UpdateTrade {

}

class UpdateTradeKyf {

}

class UpdateTradeKyfBack {

}

class UpdateGoogleToken {

}

class UpdateTokenid {
  String tokenid;

  UpdateTokenid(this.tokenid);
}

class UpdateFcm {
  String fcmBody;

  UpdateFcm(this.fcmBody);
}

class UpdateAddressBook {

}
