// An ordered list of meta tag names that denote likely article leading images.
// All attributes should be lowercase for faster case-insensitive matching.
// From most distinct to least distinct.
const LEAD_IMAGE_URL_META_TAGS = [
  'og:image',
  'twitter:image',
  'image_src',
];

const LEAD_IMAGE_URL_SELECTORS = ['link[rel=image_src]'];

const POSITIVE_LEAD_IMAGE_URL_HINTS = [
  'upload',
  'wp-content',
  'large',
  'photo',
  'wp-image',
];
final POSITIVE_LEAD_IMAGE_URL_HINTS_RE =
    RegExp(POSITIVE_LEAD_IMAGE_URL_HINTS.join('|'), caseSensitive: false);

const NEGATIVE_LEAD_IMAGE_URL_HINTS = [
  'spacer',
  'sprite',
  'blank',
  'throbber',
  'gradient',
  'tile',
  'bg',
  'background',
  'icon',
  'social',
  'header',
  'hdr',
  'advert',
  'spinner',
  'loader',
  'loading',
  'default',
  'rating',
  'share',
  'facebook',
  'twitter',
  'theme',
  'promo',
  'ads',
  'wp-includes',
];
final NEGATIVE_LEAD_IMAGE_URL_HINTS_RE =
    RegExp(NEGATIVE_LEAD_IMAGE_URL_HINTS.join('|'), caseSensitive: false);

final GIF_RE = RegExp(r'\.gif(\?.*)?$', caseSensitive: false);
final JPG_RE = RegExp(r'\.jpe?g(\?.*)?$', caseSensitive: false);
