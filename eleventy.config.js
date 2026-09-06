export default function (eleventyConfig) {

  eleventyConfig.addPassthroughCopy({
    "src/assets": "assets",
    "public": "/",
    "admin": "admin"
  });

  eleventyConfig.addCollection("posts", (collectionApi) => {
    return collectionApi
      .getFilteredByGlob("content/posts/**/*.md")
      .sort((a, b) => b.date - a.date);
  });

  eleventyConfig.addCollection("notes", (collectionApi) => {
    return collectionApi
      .getFilteredByGlob("content/notes/**/*.md")
      .sort((a, b) => b.date - a.date);
  });

  eleventyConfig.addFilter("readableDate", (dateObj) => {
    return new Intl.DateTimeFormat("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
      timeZone: "America/Chicago"
    }).format(new Date(dateObj));
  });

  eleventyConfig.addFilter("readableDateTime", (dateObj) => {
    return new Intl.DateTimeFormat("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "numeric",
      minute: "2-digit",
      timeZone: "America/Chicago"
    }).format(new Date(dateObj));
  });

  eleventyConfig.addFilter("htmlDateString", (dateObj) => {
    const date = new Date(dateObj);

    const parts = new Intl.DateTimeFormat("en-US", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      timeZone: "America/Chicago"
    }).formatToParts(date);

    const get = (type) =>
      parts.find((part) => part.type === type)?.value;

    return `${get("year")}-${get("month")}-${get("day")}`;
  });

  return {
    dir: {
      input: ".",
      includes: "src/_includes",
      data: "src/_data",
      output: "_site"
    },

    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk"
  };
}
