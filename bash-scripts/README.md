# install_custom_base_packages.sh

This script automates the installation of a set of custom base packages on your system.

> [!WARNING]
> Warning! Only execute any bash-scripts if you trust their source!

## Prerequisites

- Bash shell
- Sudo privileges

## Usage

### Open the terminal in your distro

Go to the download directory where you downloaded the install_custom_base_packages.sh file and the .env file.
Enter the command below to give the bash script the necessary permissions to execute.

```bash
chmod +x install_custom_base_packages.sh

# With the following command, you execute the bash script

./install_custom_base_packages.sh
```

## What It Does

- Updates package lists
- Installs a predefined list of base packages (edit the script to customize)

## Customization

To change which packages are installed, edit the `PACKAGES` variable inside the script.

## Example

```bash
# Inside install_custom_base_packages.sh
PACKAGES=(
    curl
    git
    vim
    # add or remove packages as needed
)
```

## Notes

- Review the script before running.
- May require internet access for package downloads.

## License

See [LICENSE](../LICENSE) for details.