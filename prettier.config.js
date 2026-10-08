/** @type {import("prettier").Config} */
const config = {
	// Tabs let each reader pick their own indent width (an accessibility win over fixed spaces).
	useTabs: true,
	singleQuote: true,
	trailingComma: 'all',
	printWidth: 100,
	plugins: ['prettier-plugin-svelte'],
	overrides: [{ files: '*.svelte', options: { parser: 'svelte' } }],
};

export default config;
