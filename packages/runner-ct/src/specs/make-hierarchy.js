
// interface SpecFolder {
//   type: 'folder'
//   name: string
//   specs: Spec[]
// }

// interface SpecFile {
//   type: 'file'
//   name: string
// }

// type Spec = SpecFolder | SpecFile

/**
 * {
 *   'make-dir': [{}]
 *   'make-dir/bar': [{}]
 * }

/**
 * Split specs into group by their
 * first level of folder hierarchy
 *
 * @param {Array<{name: string}>} specs
 */
module.exports.makeSpecHierarchy = function makeSpecHierarchy (specs) {
  return specs.reduce((groups, spec) => {
    const pathArray = spec.name.split('/')

    let currentGroup = groups

    pathArray.forEach((pathPart, i) => {
      const tmpGroup = currentGroup[pathPart] || {}

      if (i < pathArray.length - 1) {
        currentGroup[pathPart] = tmpGroup
        currentGroup = tmpGroup
      } else {
        currentGroup[pathPart] = spec
      }
    })

    return groups
  }, {})
}