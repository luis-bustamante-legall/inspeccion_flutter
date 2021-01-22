class Configuration {
  //Deep link config
  static final scheme = "https";
  static final path = "/inspeccion-virtual";
  static final keyId = "hash";

  //Azure config
  static final azureStorageAccount = {
    'protocol': 'https',
    'accountName': 'legallstorage',
    'SASToken': 'sv=2019-12-12&ss=f&srt=sco&sp=rwdlc&se=2021-01-23T05:24:49Z&st=2021-01-22T21:24:49Z&spr=https&sig=Nb9o%2FcanU8ov0AOZmGGnUlS4wnnweOFvkxq6xoBI%2FNA%3D'
  };
}