# Mitigation for CVE-2026-66066: refuse libvips' "unfuzzed" (unsafe) format
# loaders/savers when processing untrusted uploads (e.g. Active Storage variants).
# Defense-in-depth alongside the activestorage 8.1.3.1 upgrade. Requires ruby-vips >= 2.2.1.
Vips.block_untrusted(true) if defined?(Vips) && Vips.respond_to?(:block_untrusted)
