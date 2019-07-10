#~/miniconda3/bin/python

import subprocess
def mybug():
    # subprocess.run("Rscript -e \"shiny::runApp('NBClust_program',launch.browser=TRUE)\"", shell=True, timeout=60)
    subprocess.check_output("Rscript -e \"shiny::runApp('NBClust_program',launch.browser=TRUE)\"", shell=True)
mybug()
