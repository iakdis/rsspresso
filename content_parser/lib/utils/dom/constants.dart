// Spacer images to be removed
final SPACER_RE = RegExp(r'transparent|spacer|blank', caseSensitive: false);

// The class we will use to mark elements we want to keep
// but would normally remove
const KEEP_CLASS = 'mercury-parser-keep';

const KEEP_SELECTORS = [
  'iframe[src^="https://www.youtube.com"]',
  'iframe[src^="https://www.youtube-nocookie.com"]',
  'iframe[src^="http://www.youtube.com"]',
  'iframe[src^="https://player.vimeo"]',
  'iframe[src^="http://player.vimeo"]',
  'iframe[src^="https://www.redditmedia.com"]',
];

// A list of tags to strip from the output if we encounter them.
const STRIP_OUTPUT_TAGS = [
  'title',
  'script',
  'noscript',
  'link',
  'style',
  'hr',
  'embed',
  'iframe',
  'object',
];

// cleanAttributes
const REMOVE_ATTRS = ['style', 'align'];
final REMOVE_ATTR_SELECTORS =
    REMOVE_ATTRS.map((selector) => '[$selector]').toList();
final REMOVE_ATTR_LIST = REMOVE_ATTRS.join(',');
const WHITELIST_ATTRS = [
  'src',
  'srcset',
  'sizes',
  'type',
  'href',
  'class',
  'id',
  'alt',
  'xlink:href',
  'width',
  'height',
];

final WHITELIST_ATTRS_RE = RegExp(
  '^(${WHITELIST_ATTRS.join('|')})\$',
  caseSensitive: false,
);

// removeEmpty
const REMOVE_EMPTY_TAGS = ['p'];
final REMOVE_EMPTY_SELECTORS =
    REMOVE_EMPTY_TAGS.map((tag) => '$tag:empty').join(',');

// cleanTags
final CLEAN_CONDITIONALLY_TAGS = [
  'ul',
  'ol',
  'table',
  'div',
  'button',
  'form',
].join(',');

// cleanHeaders
const HEADER_TAGS = ['h2', 'h3', 'h4', 'h5', 'h6'];
final HEADER_TAG_LIST = HEADER_TAGS.join(',');

// // CONTENT FETCHING CONSTANTS ////

// A list of strings that can be considered unlikely candidates when
// extracting content from a resource. These strings are joined together
// and then tested for existence using re:test, so may contain simple,
// non-pipe style regular expression queries if necessary.
const UNLIKELY_CANDIDATES_BLACKLIST = [
  'ad-break',
  'adbox',
  'advert',
  // ... other elements omitted for brevity
];

final UNLIKELY_CANDIDATES_BLACKLIST_RE =
    RegExp(UNLIKELY_CANDIDATES_BLACKLIST.join('|'), caseSensitive: false);

// A list of strings that can be considered LIKELY candidates when
// extracting content from a resource. Essentially, the inverse of the
// blacklist above - if something matches both blacklist and whitelist,
// it is kept. This is useful, for example, if something has a className
// of "rss-content entry-content". It matched 'rss', so it would normally
// be removed, however, it's also the entry content, so it should be left
// alone.
//
// These strings are joined together and then tested for existence using
// re:test, so may contain simple, non-pipe style regular expression queries
// if necessary.
const UNLIKELY_CANDIDATES_WHITELIST = [
  'and',
  'article',
  'body',
  'blogindex',
  'column',
  'content',
  // ... other elements omitted for brevity
];

final UNLIKELY_CANDIDATES_WHITELIST_RE =
    RegExp(UNLIKELY_CANDIDATES_WHITELIST.join('|'), caseSensitive: false);

// A list of tags which, if found inside, should cause a <div /> to NOT
// be turned into a paragraph tag. Shallow div tags without these elements
// should be turned into <p /> tags.
final DIV_TO_P_BLOCK_TAGS = [
  'a',
  'blockquote',
  'dl',
  'div',
  'img',
  'p',
  'pre',
  'table',
].join(',');

// A list of tags that should be ignored when trying to find the top candidate
// for a document.
const NON_TOP_CANDIDATE_TAGS = [
  'br',
  'b',
  'i',
  'label',
  'hr',
  'area',
  'base',
  'basefont',
  'input',
  'img',
  'link',
  'meta',
];

final NON_TOP_CANDIDATE_TAGS_RE =
    RegExp('^(${NON_TOP_CANDIDATE_TAGS.join('|')})\$');

// A list of selectors that specify, very clearly, either hNews or other
// very content-specific style content, like Blogger templates.
// More examples here: http://microformats.org/wiki/blog-post-formats
const HNEWS_CONTENT_SELECTORS = [
  ['.hentry', '.entry-content'],
  ['entry', '.entry-content'],
  ['.entry', '.entry_content'],
  ['.post', '.postbody'],
  ['.post', '.post_body'],
  ['.post', '.post-body'],
];

final HNEWS_CONTENT_SELECTORS_RE = HNEWS_CONTENT_SELECTORS
    .map((selectors) => selectors.join(' '))
    .map((selector) => RegExp(selector, caseSensitive: false))
    .toList();

const PHOTO_HINTS = ['figure', 'photo', 'image', 'caption'];
final PHOTO_HINTS_RE = RegExp(PHOTO_HINTS.join('|'), caseSensitive: false);

// A list of strings that denote a positive scoring for this content as being
// an article container. Checked against className and id.
//
// TODO: Perhaps have these scale based on their odds of being quality?
const POSITIVE_SCORE_HINTS = [
  'article',
  'articlecontent',
  'instapaper_body',
  'blog',
  'body',
  'content',
  // ... other elements omitted for brevity
];

final POSITIVE_SCORE_RE =
    RegExp(POSITIVE_SCORE_HINTS.join('|'), caseSensitive: false);

// Readability publisher-specific guidelines
final READABILITY_ASSET = RegExp('entry-content-asset', caseSensitive: false);

// A list of strings that denote a negative scoring for this content as being
// an article container. Checked against className and id.
//
// TODO: Perhaps have these scale based on their odds of being quality?
const NEGATIVE_SCORE_HINTS = [
  'adbox',
  'advert',
  'author',
  'bio',
  'bookmark',
  // ... other elements omitted for brevity
];

final NEGATIVE_SCORE_RE =
    RegExp(NEGATIVE_SCORE_HINTS.join('|'), caseSensitive: false);

// XPath to try to determine if a page is wordpress. Not always successful.
const IS_WP_SELECTOR = 'meta[name=generator][value^=WordPress]';

// Match a digit. Pretty clear.
final DIGIT_RE = RegExp('[0-9]');

// A list of words that, if found in link text or URLs, likely mean that
// this link is not a next page link.
const EXTRANEOUS_LINK_HINTS = [
  'print',
  'archive',
  'comment',
  'discuss',
  // ... other elements omitted for brevity
];

final EXTRANEOUS_LINK_HINTS_RE =
    RegExp(EXTRANEOUS_LINK_HINTS.join('|'), caseSensitive: false);

// Match any phrase that looks like it could be page, or paging, or pagination
final PAGE_RE = RegExp('pag(e|ing|inat)', caseSensitive: false);

// Match any link text/classname/id that looks like it could mean the next
// page. Things like: next, continue, >, >>, » but not >|, »| as those can
// mean last page.
final NEXT_LINK_TEXT_RE = RegExp('(next|weiter|continue|>([^|]|\$)|»([^|]|\$))',
    caseSensitive: false);

// Match any link text/classname/id that looks like it is an end link: things
// like "first", "last", "end", etc.
final CAP_LINK_TEXT_RE = RegExp('(first|last|end)', caseSensitive: false);

// Match any link text/classname/id that looks like it means the previous
// page.
final PREV_LINK_TEXT_RE =
    RegExp('(prev|earl|old|new|<|«)', caseSensitive: false);

// Match 2 or more consecutive <br> tags
final BR_TAGS_RE = RegExp('(<br[^>]*>[ \n\r\t]*){2,}', caseSensitive: false);

// Match 1 BR tag.
final BR_TAG_RE = RegExp('<br[^>]*>', caseSensitive: false);

// A list of all of the block level tags known in HTML5 and below. Taken from
// http://bit.ly/qneNIT
const BLOCK_LEVEL_TAGS = [
  'article',
  'aside',
  'blockquote',
  // ... other elements omitted for brevity
];

final BLOCK_LEVEL_TAGS_RE =
    RegExp('^(${BLOCK_LEVEL_TAGS.join('|')})\$', caseSensitive: false);

// The removal is implemented as a blacklist and whitelist, this test finds
// blacklisted elements that aren't whitelisted. We do this all in one
// expression-both because it's only one pass, and because this skips the
// serialization for whitelisted nodes.
final candidatesBlacklist = UNLIKELY_CANDIDATES_BLACKLIST.join('|');
final CANDIDATES_BLACKLIST = RegExp(candidatesBlacklist, caseSensitive: false);

final candidatesWhitelist = UNLIKELY_CANDIDATES_WHITELIST.join('|');
final CANDIDATES_WHITELIST = RegExp(candidatesWhitelist, caseSensitive: false);

final UNLIKELY_RE = RegExp('!($candidatesWhitelist)|($candidatesBlacklist)',
    caseSensitive: false);

final PARAGRAPH_SCORE_TAGS = RegExp('^(p|li|span|pre)\$', caseSensitive: false);
final CHILD_CONTENT_TAGS =
    RegExp('^(td|blockquote|ol|ul|dl)\$', caseSensitive: false);
final BAD_TAGS = RegExp('^(address|form)\$', caseSensitive: false);

final HTML_OR_BODY_RE = RegExp('^(html|body)\$', caseSensitive: false);
