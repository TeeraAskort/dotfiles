nix-env -iA nixos.fido2luks

echo "Tap on your FIDO2 device"

export FIDO2_LABEL="/dev/nvme0n1p2 @ link-gl63-8rc" 
cred=$(fido2luks credential "$FIDO2_LABEL")

fido2luks -i add-key /dev/nvme0n1p2 $cred

sed -i "s/fidochangeme/$cred/g" hardware-configuration.nix
