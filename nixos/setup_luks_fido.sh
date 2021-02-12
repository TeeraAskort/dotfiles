export FIDO2_LABEL="/dev/nvme0n1p2 @ $HOSTNAME" 
cred=$(fido2luks credential "$FIDO2_LABEL")

fido2luks -i add-key /dev/nvme0n1p2 $cred

sed -i "s/changeme/$cred/g" hardware-configuration.nix
