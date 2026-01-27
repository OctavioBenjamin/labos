#!/bin/bash

ufw --force reset
ufw default allow outgoing
ufw enable
