let
  media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+VNdtFvcmSE5EL+qjmCUqJm3YHBu/Qj8825PDAnDIu root@nixos";
  gustavo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMXCcWmT1mdHAceSo01JSbQu/SVT5bsOGPB/JbSqLtw2 gustavo@media";
in
{
  "cloudflare.age".publicKeys = [ media gustavo ];
  "cloudflare-raw.age".publicKeys = [ media gustavo ];
}
