---
template: project.html
---
# arXiv HTML5 & Readability

**Collaborators:**
- Michael Kohlhase, Friedrich-Alexander Universität Erlangen-Nürnberg
- Ben Firshman, arXiv-Vanity
- Deyan Ginev, NIST

[<i class="fa fa-github"></i> https://github.com/cul-it/arxiv-readability](https://github.com/cul-it/arxiv-readability).

Our top priority is to provide a high-quality service to all arXiv authors and
readers. The overarching objective of this project is to significantly improve
the usability and accessibility of arXiv papers. While providing HTML is not a
panacea, it is a first step in the right direction. Specifically, we will:

- Develop a cloud-native service that provides HTML renderings from LaTeX
  source submitted to arXiv, leveraging LaTeXML.
- Demonstrate the feasibility and value of the service by providing it on an
  experimental basis, with links to HTML on the public abstract page. This will
  involve providing detailed guidance and feedback to authors about how to
  write LaTeX that generates high-quality accessible HTML.

Since its inception, arXiv’s primary distribution format has predominantly been PDF generated from LaTeX submitted by authors. While there are no plans to move away from LaTeX as the
preferred submission format, nor to abandon PDFs, we recognize the need to
provide distribution formats that make scientific papers more broadly usable
and accessible. In particular, the use of mobile devices--for which PDF is
unsuitable--to access internet resources including arXiv content is on the rise,
especially in developing countries.

Adopting HTML5 also opens up the potential for authors to integrate dynamic
content in their papers, such as embedded video or interactive elements. An
HTML5 distribution format provides a foundation for a broader array of
enhancements and integrations by third-party developers and researchers that
can add value for arXiv authors and readers.

Well-formed HTML5 (and in particular MathML for formulae) has advantages over
PDF for accessibility, particularly for use with screen readers and other
assistive technology.
