test_that("Syntax operators",{

  # mx_caps
  expect_true(all(grepl(mx_caps("ncov"),c("NCOV","ncov","NcOv","nCOV"))))
  expect_false(grepl(mx_caps("Test test"),"test  test"))

  # NEAR
  expect_true(grepl(fix_near("sysNEAR2rev"),"sys rev"))
  expect_true(grepl(fix_near(list("sysNEAR2rev","test2")[1]),"sys   test  test2 rev"))
  expect_false(grepl(fix_near("sysNEAR2rev"),"sys test test2 test3 rev"))

  # WILDCARD
  expect_true(grepl(fix_wildcard("te*t"),"text"))
  expect_true(grepl(fix_wildcard(list("te*t","test2")[1]),"test"))


  expect_true(grepl(fix_near(fix_wildcard(fix_caps("s*sNEAR4rev"))),"Sys 1 2 3 4 rev"))
  expect_true(grepl(fix_near(fix_wildcard(fix_caps("s*sNEAR4rev"))),"sis 1 2 3 4 rev"))

  # Check fix_caps doesn't reformat first character when user-defined
  # alternatives are present
  expect_false(grepl(fix_caps("[sb]et"),"Bet"))
  expect_true(grepl(fix_caps(list("Te[x]t","test2")[1]),"text"))


  # All together now! Highlights that ordering is important - fix_caps must come
  # first, as other two introduce square brackets which activates the stop() in
  # fix_caps()
  expect_true(grepl(fix_near(fix_wildcard(
    fix_caps("s*sNEAR4rev")
  )), "Sys 1 2 3 4 rev"))

  expect_true(grepl(fix_near(fix_wildcard(
    fix_caps("s*sNEAR4rev")
  )), "sis 1 2 3 4 rev"))

})
