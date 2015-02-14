*Introduction to R* workshop material
=====================================

This workshop material is based on [Bay area blues: the effect of the housing crisis][bay-area-blues], chapter in [Beautiful Data](http://www.amazon.com/Beautiful-Data-Stories-Elegant-Solutions/dp/0596157118), by Hadley Wickham, David Poole and Deborah F Swayne.

Original code from Hadley and coauthors can be accessed from their [github repository](https://github.com/hadley/sfhousing). I have modified the code to fit more into the workshop setting. I have also updated the code to work with up to date libraries.

[bay-area-blues]: http://amzn.com/0596157118 "Hadley Wickham and David Poole and Deborah F Swayne, Bay area blues: the effect of the housing crisis, Beautiful data, O'Reilly, 2009"

The R basics are based on [Advanced R](http://adv-r.had.co.nz/) book by Hadley. The book itself is great resource learning modern R.

## Getting started
I recommend using [RStudio](http://www.rstudio.com/products/RStudio/) for working with R. It's a great IDE which makes R programming easier especially for new R programmers.

[Follow RStudio installation installation instructions](http://www.rstudio.com/products/rstudio/download/)

To start working through the tutorial clone this git repository locally.
Whole environment should get setup once you load it in RStudio. It is an good idea to create an RStudio project from this repository directory . To do it: `File -> New Project -> Existing Directory` ([read about wrking with projects](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects)).

## Setup issues
### Mac OS X
If you get
```
ERROR: tar: failed to set default locale
```
when installing packages, set locale with running in shell:
```
defaults write org.R-project.R force.LANG en_US.UTF-8
```
and restart R studio.

## Continue learning
### Johns Hopkins University R Programming course on Coursera
If you want to learn more about R, you can follow a [free course on R Programming](https://www.coursera.org/course/rprog) on Coursera by Johns Hopkins University. At the moment (February 2015) the next 4-week session is sceduled to start on **March 2nd, 2015**.

### Interactive R tutorial at [Code School](https://www.codeschool.com/)
If you think commiting to coursera course is to much, you can learn R basics at your own pace following [Try R](https://www.codeschool.com/courses/try-r) online tutorial.
