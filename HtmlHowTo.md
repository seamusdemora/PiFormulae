## Mixing HTML and Markdown on GitHub

The motivation for this recipe was a **shortcoming** in Markdown. [Markdown](https://daringfireball.net/projects/markdown/) is the name of the markup language used here on GitHub... actually, that's not entirely true because GitHub has changed the Markdown syntax to create what is usually called *GitHub-Flavored Markdown*, or **GFM**. And there are other flavors of Markdown - each with something a bit different from the others. Whatever...

The **shortcoming** I'm referring to is in the rendering of **Tables** in GFM. The syntax for tables is simple enough - an example is shown below. However, this table is rendered in a fashion that makes for a *really ugly Table*! 

| Column1                    | Column2                    |
| -------------------------- | -------------------------- |
| Some text goes in Column 1 | More text goes in Column 2 |
| But the question is this: | Why is the table rendered in a lopsided fashion? |
| This may be a consequence of the | fact that Markdown tables do not provide a mechanism to allow the writer to control the width of the columns |

The Markdown *source code* for the table above follows. It's simple, and it produces acceptable results occasionally. But often the column widths assigned by the rendering engine aren't well-suited to the content: 
```
| Column1 | Column2  |
| ------------- | -------------- |
| Some text goes in Column 1 | More text goes in Column 2 |
| But the question is this:  | Why is the table rendered in a lopsided fashion? |
| This may be a consequence of the | fact that Markdown tables do not provide a mechanism to allow the writer to control the width of the columns |
```

The solution is to fall back on HTML for tables. Good results are obtained when the table is rendered IAW a *style sheet*, or CSS. This recipe illustrates how to do that. An HTML table is shown below for comparison.

<html>

<table class="minimalistBlack">
<thead>
<tr>
<th width="40%">Column1</th>
<th width="60%">Column2</th>
</tr>
</thead>
<tbody>
<tr>
<td>Some text goes in Column 1</td>
<td>More text goes in Column 2</td>
</tr>
<tr>
<td>But the question is this:</td>
<td>Why is the table rendered in a lopsided fashion?</td>
</tr>
<tr>
<td>This may be a consequence of the</td>
<td>fact that Markdown tables do not provide a mechanism to allow the writer to control the width of the columns</td>
</tr>
<tr>
<td>In this HTML table OTOH</td>
<td>Column 1 has been allocated 40% of the width, while Column 2 gets the remaining 60%</td>
</tr>
<tr>
<td>And this control</td>
<td>makes a difference in the way the table looks.</td>
</tr>
</tbody>
</table> 
</html>

---

How is this done? You can discover that by looking at the source code for this page, and observing that there is a [folder named `css`](https://github.com/seamusdemora/PiFormulae/tree/master/css) in this repo (see it at the top of [this page](https://github.com/seamusdemora/PiFormulae)). The folder `css` contains a file -  the CSS *style sheet* used to render some of the tables in this repo. Feel free to copy any or all of this. 


