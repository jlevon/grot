#!/bin/bash

lspci -k | grep -i vfio-pci -B2
