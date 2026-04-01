# Sample Prompts for Claude with testmu-browser-agent-public

These prompts demonstrate what you can ask Claude once testmu-browser-agent-public is configured as an MCP server.

---

## 1. Web Research — Hacker News

> "Go to https://news.ycombinator.com, take a snapshot of the page, and list the top 10 story titles with their point counts."

Claude will open Hacker News, extract the front-page stories, and return a structured list.

---

## 2. Form Automation — httpbin

> "Navigate to https://httpbin.org/forms/post, fill in the customer name as 'Jane Doe', the telephone as '555-1234', the email as 'jane@example.com', select 'medium' pizza size, add 'bacon' and 'cheese' toppings, then submit the form and show me the response."

Claude will locate each field, fill them in, submit, and display the JSON echo response from httpbin.

---

## 3. Data Extraction — Books to Scrape

> "Open https://books.toscrape.com, navigate to the Mystery category, and extract the title, price, and star rating for every book on the first page. Return the data as a markdown table."

Claude will scrape the listing page and format the results for easy reading.

---

## 4. Visual Testing — Responsive Screenshots

> "Take screenshots of https://getbootstrap.com at three viewport widths: 375px (mobile), 768px (tablet), and 1440px (desktop). Show me all three screenshots so I can compare the responsive layout."

Claude will resize the viewport for each shot and return the three images inline.

---

## 5. Authenticated Workflow — The Internet (Herokuapp)

> "Go to https://the-internet.herokuapp.com/login, log in with username 'tomsmith' and password 'SuperSecretPassword!', verify that the page says 'Secure Area' after login, then take a screenshot of the authenticated state."

Claude will handle the login flow end-to-end and confirm the success message.

---

## 6. Multi-Tab Research — Wikipedia Comparison

> "Open three tabs: the Wikipedia articles for 'Go (programming language)', 'Rust (programming language)', and 'TypeScript'. From each article, extract the 'Paradigm' and 'Designed by' fields from the infobox. Summarize the differences in a comparison table."

Claude will manage multiple tabs, extract structured data from each, and synthesize a side-by-side comparison.
