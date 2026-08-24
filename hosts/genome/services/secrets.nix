{
  age.secrets."hosts/genome/nextauth-secret.age" = {
    owner = "linkwarden";
    group = "linkwarden";
    mode = "0400";
  };

  age.secrets."hosts/genome/meili-master-key.age" = {
    owner = "linkwarden";
    group = "linkwarden";
    mode = "0400";
  };
}
