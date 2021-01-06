class Configuration {
  //Deep link config
  static final scheme = "https";
  static final path = "/inspeccion-virtual";
  static final keyId = "hash";

  //Azure config
  static final azureStorageAccount = {
    'protocol': 'https',
    'accountName': 'legallstorageaccount',
    'SASToken': 'sv=2019-12-12&ss=bfqt&srt=sco&sp=rwdlacupx&se=2026-03-30T04:12:46Z&st=2021-01-05T20:12:46Z&spr=https&sig=pMeH%2FfYdKITmEKwqctmPl6Uxjn0%2B6RoUmsgbJxZ%2FZfM%3D'
  };
}