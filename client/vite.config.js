import { defineConfig } from 'vite'

export default defineConfig({
	css: {
		preprocessorOptions: {
			scss: {
				additionalData: `
					@use "sass:math";
					@use "src/styles/global.scss" as *;
				`
			  }
		}
	}
});